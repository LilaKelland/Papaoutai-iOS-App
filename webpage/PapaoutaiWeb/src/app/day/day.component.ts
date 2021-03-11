import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-day',
  templateUrl: './day.component.html',
  styleUrls: ['./day.component.css']
})
export class DayComponent implements OnInit {
  linegraph: boolean;


  constructor() { 
    this.linegraph = true;
  }

  label() {
    return (this.linegraph) ? 'Display Linegraph' : 'Display barchart';
  }

  onLinegraphToggle(event: any) {
    this.linegraph = !this.linegraph;
    console.log('Event handler invoked on element ' + event.target);

  }

  ngOnInit(): void {
  }

}
